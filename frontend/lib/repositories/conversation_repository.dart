// lib/repositories/conversation_repository.dart
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ConversationRepository {
  final ApiService _apiService;

  ConversationRepository(this._apiService);

  // Get all conversations for the current user
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _apiService.get('conversation');

      if (response is List) {
        return response.map((data) => Conversation.fromJson(data)).toList();
      } else {
        return (response as List<dynamic>)
            .map((data) => Conversation.fromJson(data))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  // Create a new conversation
  Future<Conversation> createConversation(String title) async {
    try {
      final data = {'title': title};

      final response = await _apiService.post('conversation', data);
      return Conversation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Get a single conversation by ID
  Future<Conversation> getConversation(String id) async {
    try {
      final response = await _apiService.get('conversation/$id');
      return Conversation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch conversation: $e');
    }
  }

  // Update conversation title
  Future<Conversation> updateConversation(String id, String title) async {
    try {
      final data = {'title': title};

      final response = await _apiService.put('conversation/$id', data);
      return Conversation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String id) async {
    try {
      await _apiService.delete('conversation/$id');
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Get messages for a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final response = await _apiService.get(
        'conversation/$conversationId/messages',
      );

      if (response is List) {
        return response.map((data) => Message.fromJson(data)).toList();
      } else {
        return (response as List<dynamic>)
            .map((data) => Message.fromJson(data))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  // Send a message in a conversation
  Future<List<Message>> sendMessage(
    String conversationId,
    String content, {
    Map<String, dynamic>? meta,
  }) async {
    try {
      final payload = {'content': content, if (meta != null) 'meta': meta};

      final response = await _apiService.post(
        'conversation/$conversationId/messages',
        payload,
      );

      if (response is List) {
        return response.map((data) => Message.fromJson(data)).toList();
      } else {
        return (response as List<dynamic>)
            .map((data) => Message.fromJson(data))
            .toList();
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
