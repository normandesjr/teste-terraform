resource "aws_sqs_queue" "test_sqs_1" {
  name = "test-queue-1"
}

resource "aws_sqs_queue" "test_sqs_2" {
  name = "test-queue-2"
}

resource "aws_sns_topic_subscription" "test_subscription_1" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = aws_sns_topic.test_sns_1.arn
  endpoint             = aws_sqs_queue.test_sqs_1.arn
}

resource "aws_sns_topic_subscription" "test_subscription_2" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = aws_sns_topic.test_sns_1.arn
  endpoint             = aws_sqs_queue.test_sqs_2.arn
}

resource "aws_sqs_queue_policy" "sns_to_sqs_1_subscription" {
  queue_url = aws_sqs_queue.test_sqs_1.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.test_sqs_1.arn}"
      ],
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.test_sns_1.arn}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_sqs_queue_policy" "sns_to_sqs_2_subscription" {
  queue_url = aws_sqs_queue.test_sqs_2.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.test_sqs_2.arn}"
      ],
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.test_sns_1.arn}"
        }
      }
    }
  ]
}
EOF
}