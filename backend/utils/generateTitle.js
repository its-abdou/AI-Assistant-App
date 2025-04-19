import ModelClient, { isUnexpected } from "@azure-rest/ai-inference";
import { AzureKeyCredential } from "@azure/core-auth";

const endpoint = "https://models.github.ai/inference";
const token = process.env["GITHUB_TOKEN"];
const model = "openai/gpt-4.1";

const client = ModelClient(endpoint, new AzureKeyCredential(token));

export async function generateTitleFromMessages(userContent, assistantContent) {
  const prompt = `Give a short and clear title for this conversation:\n\nUser: ${userContent}\nAssistant: ${assistantContent}`;

  const response = await client.path("/chat/completions").post({
    body: {
      model,
      messages: [{ role: "user", content: prompt }],
      temperature: 0.5,
      top_p: 1,
    },
  });

  if (isUnexpected(response)) {
    console.error("Error generating title:", response.body.error);
    return "New Conversation";
  }

  return response.body.choices[0].message.content.trim();
}
