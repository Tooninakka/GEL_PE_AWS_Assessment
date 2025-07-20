output "bucket_a_name" {
  value = aws_s3_bucket.source_bucket.bucket
}

output "bucket_b_name" {
  value = aws_s3_bucket.destination_bucket.bucket
}

output "user_a_name" {
  value = aws_iam_user.user_a.name
}

output "user_b_name" {
  value = aws_iam_user.user_b.name
}