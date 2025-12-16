pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sanjeevkumartc666/Jenkinsandjava.git'
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'jenkinsecr'
        // NOTE: This ECR URI '311145409616...' is for a PRIVATE ECR in ap-south-1, 
        // but your login stage uses 'public.ecr.aws' (us-east-1). These must match.
        ECR_PUBLIC_REPO_URI = 'public.ecr.aws/i0m8d5u6/jenkinsecr' 
        IMAGE_TAG = 'latest'
        AWS_ACCOUNT_ID = '311145409616'
        IMAGE_URI = "${ECR_PUBLIC_REPO_URI}:${IMAGE_TAG}"
        
    }

    stages {
        stage('Install AWS CLI') {
            steps {
                script {
                    sh '''
                        set -e
                        echo "Installing AWS CLI..."
                        sudo apt update && sudo apt install -y unzip curl

                        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        rm -rf aws
                        unzip -q awscliv2.zip
                        sudo ./aws/install --update
                        aws --version
                    '''
                }
            }
        }

        // REMOVE the 'Configure AWS Credentials' stage entirely and use this instead:
        stage('Login to AWS ECR, Build & Push Docker Image') {
            steps {
                // This block injects the securely stored credentials into the environment variables
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        echo "Logging into AWS ECR Public..."
                        # The 'aws' CLI automatically uses the injected ENV variables to authenticate
                        aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_PUBLIC_REPO_URI}

                        echo "Building Docker image: ${IMAGE_URI}"
                        docker build -t ${IMAGE_URI} .

                        echo "Pushing Docker image to ECR..."
                        docker push ${IMAGE_URI}
                    '''
                }
            }
        }


    
    post {
        success {
            echo "Docker image pushed to ECR successfully and deployed."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
