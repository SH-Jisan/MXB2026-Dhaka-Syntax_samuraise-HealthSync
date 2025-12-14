import { GoogleGenerativeAI } from "https://esm.sh/@google/generative-ai"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { imageBase64, mimeType } = await req.json()
    const apiKey = Deno.env.get('GEMINI_API_KEY')
    if (!apiKey) throw new Error('GEMINI_API_KEY not set')

    const genAI = new GoogleGenerativeAI(apiKey)
    // 2.5 Flash is great for OCR and reasoning
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

    // 🔥 POWERFUL PROMPT ENGINEERING 🔥
    const prompt = `
    Role: You are an expert Medical Data Analyst.
    Task:
    1. OCR: Read every single word from this medical document image perfectly.
    2. Analyze: Understand the medical context, abnormal values, and diagnosis.

    Output Format: Return ONLY a valid JSON object with this exact structure:
    {
      "title": "Short generic title (e.g., CBC Report, Prescription by Dr. X)",
      "event_type": "REPORT" or "PRESCRIPTION" or "SURGERY",
      "event_date": "YYYY-MM-DD" (if missing, use today's date),
      "severity": "HIGH" (if critical) or "MEDIUM" or "LOW",
      "summary": "A professional 2-3 line summary of the patient's condition.",
      "extracted_text": "Full text content of the image. Preserve line breaks with \\n.",
      "key_findings": ["List of abnormal values", "Diagnosis", "Key medicines"]
    }
    `

    const result = await model.generateContent([
      prompt,
      { inlineData: { data: imageBase64, mimeType: mimeType || "image/jpeg" } },
    ])

    const text = result.response.text()
    console.log("AI Response:", text)

    const cleanedText = text.replace(/```json/g, '').replace(/```/g, '').trim()
    const jsonData = JSON.parse(cleanedText)

    return new Response(JSON.stringify(jsonData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})