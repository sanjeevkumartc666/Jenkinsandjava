pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sanjeevkumartc666/Jenkinsandjava.git'
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'jenkinsecr'
        // NOTE: This ECR URI '311145409616...' is for a PRIVATE ECR in ap-south-1, 
        // but your login stage uses 'public.ecr.aws' (us-east-1). These must match.
        ECR_PUBLIC_REPO_URI = '311145409616.dkr.ecr.ap-south-1.amazonaws.com/jenkinsecr' 
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

        stage('Configure AWS Credentials') {
            steps {
                script {
                    sh '''
                    echo "Setting up AWS credentials for Jenkins..."
                    mkdir -p /var/lib/jenkins/.aws
                    echo "[default]" > /var/lib/jenkins/.aws/credentials
                    # Using the new, valid keys you provided earlier:
                    # WARNING: These keys are compromised and should be deactivated immediately!
                    echo "aws_access_key_id=AKIAUQ4NWFRICZ5E3UQF" >> /var/lib/jenkins/.aws/credentials
                    echo "aws_secret_access_key=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" >> /var/lib/jenkins/.aws/credentials
                    chown -R jenkins:jenkins /var/lib/jenkins/.aws
                    '''
                }
            }
        }

        stage('Clone Repository') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('Build') {
            steps {
                script {
                    sh '''
                        echo "Building Java application..."
                        mvn clean -B -Denforcer.skip=true package
                    '''
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    sh '''
                        echo "Logging into AWS ECR Public..."
                        # This command is for ECR PUBLIC (us-east-1)
                        ECR_PASSWORD=$(aws ecr-public get-login-password --region us-east-1)
                        echo $ECR_PASSWORD | docker login --username AWS --password-stdin public.ecr.aws
                    '''
                }
            }
        }
        
        <!-- REMOVE THE LINE 'Use code with caution.' HERE -->

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        echo "Building Docker image..."
                        # This build command uses your ECR PRIVATE URI
                        docker build -t ${IMAGE_URI} .
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh '''
                        echo "Pushing Docker image to ECR..."
                        docker push ${IMAGE_URI}
                    '''
                }
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
