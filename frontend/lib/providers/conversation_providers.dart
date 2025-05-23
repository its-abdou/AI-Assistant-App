import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../repositories/conversation_repository.dart';
import 'auth_providers.dart';

// Conversation Repository provider
final conversationRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ConversationRepository(apiService);
});

// Conversations list state
final conversationsProvider = StateNotifierProvider<
    ConversationsNotifier,
    AsyncValue<List<Conversation>>
>((ref) {
  final conversationRepository = ref.watch(conversationRepositoryProvider);
  return ConversationsNotifier(conversationRepository);
});

class ConversationsNotifier
    extends StateNotifier<AsyncValue<List<Conversation>>> {
  final ConversationRepository _conversationRepository;

  ConversationsNotifier(this._conversationRepository)
      : super(const AsyncValue.loading()) {
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _conversationRepository.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Conversation> createConversation(String title) async {
    try {
      final newConversation = await _conversationRepository.createConversation(
        title,
      );

      // Update state with the new conversation
      state.whenData((conversations) {
        state = AsyncValue.data([newConversation, ...conversations]);
      });

      return newConversation;
    } catch (e) {
      // Don't update state on error
      rethrow;
    }
  }

  Future<void> updateConversation(String id, String title) async {
    try {
      final updatedConversation = await _conversationRepository
          .updateConversation(id, title);

      // Update the state directly
      final currentState = state;
      if (currentState is AsyncData<List<Conversation>>) {
        final updatedList =
        currentState.value
            .map((conv) => conv.id == id ? updatedConversation : conv)
            .toList();
        state = AsyncValue.data(updatedList);
      } else {
        // If state is not in data state, fetch conversations to refresh
        await fetchConversations();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      await _conversationRepository.deleteConversation(id);

      // Update the state directly
      final currentState = state;
      if (currentState is AsyncData<List<Conversation>>) {
        final updatedList =
        currentState.value.where((conv) => conv.id != id).toList();
        state = AsyncValue.data(updatedList);
      } else {
        // If state is not in data state, fetch conversations to refresh
        await fetchConversations();
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Current conversation messages state
final currentConversationProvider = StateProvider<String?>((ref) => null);

final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier,
    AsyncValue<List<Message>>,
    String
>((ref, conversationId) {
  final conversationRepository = ref.watch(conversationRepositoryProvider);
  return MessagesNotifier(conversationRepository, conversationId);
});

class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ConversationRepository _conversationRepository;
  final String conversationId;

  MessagesNotifier(this._conversationRepository, this.conversationId)
      : super(const AsyncValue.loading()) {
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    state = const AsyncValue.loading();
    try {
      final messages = await _conversationRepository.getMessages(
        conversationId,
      );
      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> sendMessage(String content, {XFile? image}) async {
    try {
      final now = DateTime.now();

      // Create metadata for display in UI
      Map<String, dynamic>? displayMeta;
      if (image != null) {
        displayMeta = {'image': image.path}; // Local path for optimistic UI
      }

      final optimisticUserMessage = Message(
        id: 'temp-${now.millisecondsSinceEpoch}',
        conversationId: conversationId,
        sender: 'user',
        content: content.isNotEmpty ? content : '[Image]',
        meta: displayMeta,
        createdAt: now,
        updatedAt: now,
      );

      final loadingAssistantMessage = Message(
        id: 'loading-${now.millisecondsSinceEpoch}',
        conversationId: conversationId,
        sender: 'assistant',
        content: '...',
        createdAt: now,
        updatedAt: now,
      );

      // Update UI with optimistic messages
      state.whenData((messages) {
        state = AsyncValue.data([
          ...messages,
          optimisticUserMessage,
          loadingAssistantMessage,
        ]);
      });

      // Send message to API
      final newMessages = await _conversationRepository.sendMessage(
        conversationId,
        content,
        image: image,
      );

      // Update state with real messages, ensuring we don't lose any previous messages
      state.whenData((messages) {
        final filteredMessages = messages
            .where((msg) =>
        msg.id != optimisticUserMessage.id &&
            msg.id != loadingAssistantMessage.id)
            .toList();

        // Make sure we keep any existing messages
        final messagesToAdd = newMessages.where((newMsg) {
          return !filteredMessages.any((msg) => msg.id == newMsg.id);
        }).toList();

        state = AsyncValue.data([...filteredMessages, ...messagesToAdd]);
      });
    } catch (e) {
      fetchMessages(); // rollback optimistic UI
      rethrow;
    }
  }
}
