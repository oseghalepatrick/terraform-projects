variable "aws_region" {
  description = "Deployment region (must support Bedrock for the infra you use)"
  type        = string
  default     = "eu-west-1"
}

variable "bedrock_region" {
  description = "Region where Bedrock is called (usually same as aws_region). Must support your chosen model."
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Short project name"
  type        = string
  default     = "bedrock-playground-demo"
}

# Pick a model you have access to in Bedrock console:
# e.g., "anthropic.claude-3-haiku-20240307" (text), "amazon.nova-lite-v1:0", etc.
variable "model_id" {
  description = "Bedrock model identifier"
  type        = string
  default     = "amazon.nova-lite-v1:0"
}
