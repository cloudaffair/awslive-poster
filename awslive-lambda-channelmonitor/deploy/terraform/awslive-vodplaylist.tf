variable "channelmonitor-pkg" {
  type    = string
  default = "../../awslive-lambda-channelmonitor.zip"
}

resource "aws_iam_role" "awslive-channelmon-role" {
  name = "awslive-channelmon-role"
  assume_role_policy = <<EOF
{"Version": "2012-10-17","Statement": [ { "Action": "sts:AssumeRole","Effect": "Allow","Principal": { "Service": ["lambda.amazonaws.com","edgelambda.amazonaws.com"]}}]}

EOF

}

resource "aws_iam_policy" "awslive-channelmon-policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "medialive:*",
        "lambda:*",
        "iam:PassRole",
        "s3:*",
        "events:*"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "awslive-channelmon-policy-attach" {
  policy_arn = "${aws_iam_policy.awslive-channelmon-policy.arn}"
  role = "${aws_iam_role.awslive-channelmon-role.name}"
}


resource "aws_lambda_function" "awslive-lambda-channelmon" {
  function_name = "awslive-lambda-channelmon"
  handler = "awslive-lambda-channelmonitor.lambda_handler"
  role = "${aws_iam_role.awslive-channelmon-role.arn}"
  runtime = "ruby2.5"
  filename         = var.channelmonitor-pkg
  source_code_hash = filebase64sha256(var.channelmonitor-pkg)
  environment {
    variables = {
      role_arn = "${aws_iam_role.awslive-channelmon-role.arn}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "awslive-lambda-channelmon-rule" {
  name = "awslive-lambda-channelmon-rule"
  event_pattern = "{\"source\":[\"aws.medialive\"],\"detail-type\": [\"MediaLive Channel State Change\"]}"
}

resource "aws_cloudwatch_event_target" "channelmon-rule-target" {
  arn = "${aws_lambda_function.awslive-lambda-channelmon.arn}"
  rule = "${aws_cloudwatch_event_rule.awslive-lambda-channelmon-rule.name}"
}

resource "aws_lambda_permission" "channelmon-permission" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.awslive-lambda-channelmon.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.awslive-lambda-channelmon-rule.arn}"
}
