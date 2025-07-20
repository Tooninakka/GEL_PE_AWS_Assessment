provider "aws" {
  region = "us-east-1" # or your preferred region
}

resource "aws_s3_bucket" "source_bucket" {
  bucket = "gel-source-bucket"
  force_destroy = true
}

resource "aws_s3_bucket" "destination_bucket" {
  bucket = "gel-destination-bucket"
  force_destroy = true
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "exif_remover" {
  filename         = "lambda_package.zip"
  function_name    = "ExifRemover"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "exif_cleaner.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10
  source_code_hash = filebase64sha256("lambda_package.zip")
  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.destination_bucket.bucket
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.exif_remover.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.exif_remover.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}