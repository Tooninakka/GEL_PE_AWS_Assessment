**Problem Statement**

The company receives user-uploaded .jpg images to an Amazon S3 bucket (Bucket A). These images must be stripped of EXIF metadata for privacy and consistency before being displayed on the website. The cleaned images are to be stored in a separate S3 bucket (Bucket B), preserving the same folder path.

Additionally, two IAM users are to be provisioned:
	•	User A: Can Read/Write to Bucket A
	•	User B: Can Read-Only from Bucket B

**Architecture Diagram**
                +----------------------+
                | S3 Bucket A          |
                | (Upload .jpg)        |
                +----------------------+
                          |
                    [S3 Trigger]
                          |
                   invokes Lambda
                          |
                +----------------------+
                | Lambda Function       |
                | - Removes EXIF        |
                | - Uploads to Bucket B |
                +----------------------+
                          |
                +----------------------+
                | S3 Bucket B          |
                | (Clean .jpg output)  |
                +----------------------+

**Technologies Used**
	•	Terraform – Infrastructure as Code
	•	AWS Services:
	•	S3 – file storage
	•	Lambda – serverless image processing
	•	IAM – permissions and users
	•	Python – EXIF removal using Pillow
  •	Zip – for packaging Lambda with dependencies
  
**Approach & Breakdown**
  * Step 1: Real-time Image Processing (S3 → Lambda → S3)
	•	Trigger: When a .jpg is uploaded to Bucket A, it triggers the Lambda function.
	•	Lambda function:
	  •	Downloads the .jpg image from Bucket A.
	  •	Uses Pillow to strip EXIF metadata by re-saving the image.
	  •	Uploads the cleaned image to Bucket B, preserving the object key (path).
	  •	Benefit: Fully event-driven and serverless. No manual intervention needed.

  * Step 2: IAM Permissions
	•	User A: Granted full s3:* access to Bucket A only.
	•	User B: Granted s3:GetObject access to Bucket B only.
	•	This is achieved using IAM policies attached to the respective users.

**Project Structure**
terraform-assessment/
├── main.tf                 # S3 buckets, Lambda, triggers
├── iam.tf                  # IAM users and policies
├── outputs.tf              # Outputs for easy reference
├── lambda/
│   ├── exif_cleaner.py     # Lambda code to remove EXIF
│   └── requirements.txt    # Python dependencies
├── lambda_package.zip      # Zipped code + libs (generated before deploy)
└── README.md               # Project documentation

**How to Run This Project**

* Prerequisites
	•	AWS CLI & credentials configured
	•	Terraform installed
	•	Python 3.8+
	•	Zip utility

* Step 1: Package the Lambda Function
cd lambda
pip install -r requirements.txt -t .
zip -r ../lambda_package.zip .
cd ..

* Step 2: Deploy Infrastructure with Terraform
terraform init
terraform apply

* Step 3: Test the Workflow
	1.	Upload .jpg image to Bucket A:
     aws s3 cp test.jpg s3://gel-source-bucket/test.jpg
     
  2.	Lambda will automatically trigger, and the cleaned image will be uploaded to Bucket B:
      aws s3 ls s3://gel-destination-bucket/
