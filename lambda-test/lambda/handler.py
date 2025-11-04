import json, os, base64, boto3

BEDROCK_REGION = os.environ.get("BEDROCK_REGION", "eu-west-1")
MODEL_ID = os.environ.get("MODEL_ID", "amazon.nova-lite-v1:0")
brt = boto3.client("bedrock-runtime", region_name=BEDROCK_REGION)

def _json_body(event):
    raw = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        raw = base64.b64decode(raw).decode("utf-8")
    return json.loads(raw)

def _payload_for_model(model_id: str, prompt: str):
    if model_id.startswith("openai."):
        # OpenAI chat completions style
        return {
            "messages": [
                {"role": "system", "content": "You are a concise assistant."},
                {"role": "user", "content": prompt}
            ],
            "max_completion_tokens": 256,
            "temperature": 0.2,
            "top_p": 0.95,
            "stream": False
        }, "openai"
    if model_id.startswith("anthropic."):
        # Anthropic Messages
        return {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 512,
            "temperature": 0.2,
            "messages": [
                {"role": "user", "content": [{"type": "text", "text": prompt}]}
            ]
        }, "anthropic"
    if model_id.startswith("amazon.nova"):
        # Nova text generation (Text API)
        return {
            "inputText": prompt,
            "textGenerationConfig": {
                "maxOutputTokens": 256,
                "temperature": 0.2,
                "topP": 0.95
            }
        }, "nova"
    # Fallback: try OpenAI style
    return {"messages": [{"role":"user","content":prompt}], "max_completion_tokens": 256}, "openai"

def _extract_text(model_family: str, obj: dict) -> str:
    try:
        if model_family == "openai":
            m = obj["choices"][0]["message"]["content"]
            if isinstance(m, str): return m
            if isinstance(m, list):
                return "".join(seg.get("text") or seg.get("content") or "" for seg in m if isinstance(seg, dict))
            return json.dumps(obj)[:4000]
        if model_family == "anthropic":
            return obj["content"][0]["text"]
        if model_family == "nova":
            return obj.get("outputText") or json.dumps(obj)[:4000]
    except Exception:
        pass
    return json.dumps(obj)[:4000]

def handler(event, context):
    try:
        method = event.get("requestContext", {}).get("http", {}).get("method", "GET")
        if method == "GET":
            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/json"},
                "body": json.dumps({
                    "message": "POST {'prompt':'your text'} to call Bedrock.",
                    "model_id": MODEL_ID,
                    "bedrock_region": BEDROCK_REGION
                })
            }

        data = _json_body(event)
        prompt = data.get("prompt", "Say hello from Bedrock!")

        payload, family = _payload_for_model(MODEL_ID, prompt)
        resp = brt.invoke_model(
            modelId=MODEL_ID,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(payload)
        )
        obj = json.loads(resp["body"].read().decode("utf-8"))
        text = _extract_text(family, obj)

        return {
            "statusCode": 200,
            "headers": {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"model_id": MODEL_ID, "family": family, "output": text})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json", "Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
