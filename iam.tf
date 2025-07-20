# User A: Read/Write to Bucket A
resource "aws_iam_user" "user_a" {
  name = "UserA"
}

resource "aws_iam_policy" "user_a_policy" {
  name = "UserA_S3_Access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:*"],
      Resource = [
        "${aws_s3_bucket.source_bucket.arn}",
        "${aws_s3_bucket.source_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_user_policy_attachment" "attach_user_a" {
  user       = aws_iam_user.user_a.name
  policy_arn = aws_iam_policy.user_a_policy.arn
}

# User B: Read-only to Bucket B
resource "aws_iam_user" "user_b" {
  name = "UserB"
}

resource "aws_iam_policy" "user_b_policy" {
  name = "UserB_Read_Only"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["s3:GetObject"],
      Resource = "${aws_s3_bucket.destination_bucket.arn}/*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "attach_user_b" {
  user       = aws_iam_user.user_b.name
  policy_arn = aws_iam_policy.user_b_policy.arn
}