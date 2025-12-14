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
    const { imageBase64, mimeType, patient_id, uploader_id, file_url } = await req.json()

    // 1. Environment Variables Check
    const apiKey = Deno.env.get('GEMINI_API_KEY')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!apiKey || !supabaseUrl || !supabaseServiceKey) {
      throw new Error('Missing environment variables!')
    }

    // 2. Initialize Clients
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const genAI = new GoogleGenerativeAI(apiKey)
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" })

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
      "summary": "Concise summary.",
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
    const newTitle = aiData['title'] ?? 'Medical Document'
    const newDate = aiData['event_date'] ?? new Date().toISOString().split('T')[0]

    const { data: duplicates } = await supabase
      .from('medical_events')
      .select('id')
      .eq('patient_id', patient_id)
      .eq('title', newTitle)
      .eq('event_date', newDate)

    if (duplicates && duplicates.length > 0) {
      return new Response(JSON.stringify({ error: "Duplicate: This record already exists." }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 409,
      })
    }

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
        ai_details: aiData // Full JSON for future use
      })

    if (insertError) throw insertError

    // 7. Update Profile Summary (Rolling Update Feature) - Optional for now
    // এটা পরে আমরা আলাদা ট্রিগার দিয়েও করতে পারি।

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