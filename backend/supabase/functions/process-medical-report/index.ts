import { GoogleGenerativeAI } from "https://esm.sh/@google/generative-ai"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // CORS Handle
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { imageBase64, mimeType, patient_id, uploader_id, file_url, file_hash, file_path } = await req.json()

    const apiKey = Deno.env.get('GEMINI_API_KEY')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!apiKey || !supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing environment variables!')
    }

    // 2. Initialize Clients
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    // 🛑 1. DUPLICATE CHECK (Based on Hash) - AI এর আগে চেক করছি খরচ বাঁচাতে
    if (file_hash) {
      const { data: duplicates } = await supabase
        .from('medical_events')
        .select('id')
        .eq('patient_id', patient_id)
        .eq('file_hash', file_hash) // টাইটেল না, হ্যাশ দিয়ে চেক

      if (duplicates && duplicates.length > 0) {
        // 🗑️ ডুপ্লিকেট হলে স্টোরেজ থেকে ফাইলটি ডিলিট করে দেওয়া (Clean up)
        if (file_path) {
          await supabase.storage.from('reports').remove([file_path])
        }

        return new Response(JSON.stringify({ error: "Duplicate File" }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 409, // Conflict status code
        })
      }
    }
    const genAI = new GoogleGenerativeAI(apiKey)
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-pro" })

    // 3. Smart Prompt (Prescription Safety Check সহ)
    const prompt = `
    Role: Expert Medical AI.
    Task:
    1. EXTRACT every single word (OCR).
    2. Identify Document Type: REPORT or PRESCRIPTION.
    3. Analyze findings. If Prescription, check for common contraindications.

    Output JSON format (Strictly):
    {
      "title": "Short descriptive title",
      "event_type": "REPORT" or "PRESCRIPTION",
      "event_date": "YYYY-MM-DD",
      "severity": "HIGH/MEDIUM/LOW",
      "summary": "Concise summary in English.",
      "summary_bn": "সারাংশ (Summary in Bengali).",
      "extracted_text": "Full text content...",
      "key_findings": ["Hb: 10.5 (Low)", "Platelets: Normal"],
      "medicine_safety_check": "Safe/Caution/Danger (Only for prescriptions)"
    }
    `

    // 4. AI Call
    const result = await model.generateContent([
      prompt,
      { inlineData: { data: imageBase64, mimeType: mimeType || "image/jpeg" } },
    ])

    const text = result.response.text()
    const cleanedText = text.replace(/```json/g, '').replace(/```/g, '').trim()
    const aiData = JSON.parse(cleanedText)

    // 5. Duplicate Check (Server Side)
    const newTitle = aiData['title'] || 'Medical Document'
    const rawDate = aiData['event_date']
    const newDate = (rawDate && rawDate.trim() !== "")
      ? rawDate
      : new Date().toISOString().split('T')[0]

    // 6. Secure Database Insert
    // আমরা uploader_id আলাদা সেভ করছি যাতে বোঝা যায় কে আপলোড করেছে (Hospital/Self)
    const { error: insertError } = await supabase
      .from('medical_events')
      .insert({
        patient_id: patient_id,
        uploader_id: uploader_id, // কে আপলোড করল
        title: newTitle,
        event_type: aiData['event_type'] ?? 'REPORT',
        event_date: newDate,
        severity: aiData['severity'] ?? 'LOW',
        summary: aiData['summary'],
        extracted_text: aiData['extracted_text'],
        key_findings: aiData['key_findings'],
        attachment_urls: [file_url],
        file_hash: file_hash,
        ai_details: aiData // Full JSON for future use
      })

    if (insertError) throw insertError

    return new Response(JSON.stringify({ success: true, data: aiData }), {
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