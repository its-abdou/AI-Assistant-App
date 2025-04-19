import axios from "axios";
export async function getBase64FromUrl(url) {
  try {
    // Download the image
    const response = await axios.get(url, { responseType: "arraybuffer" });

    // Convert to base64
    const base64 = Buffer.from(response.data, "binary").toString("base64");

    // Determine the mime type (basic implementation)
    let mimeType = "image/jpeg"; // Default
    if (url.endsWith(".png")) mimeType = "image/png";
    if (url.endsWith(".gif")) mimeType = "image/gif";
    if (url.endsWith(".webp")) mimeType = "image/webp";

    // Return full base64 string with data URI scheme
    return `data:${mimeType};base64,${base64}`;
  } catch (error) {
    console.error("Error downloading image:", error);
    throw new Error("Failed to download and encode image");
  }
}
