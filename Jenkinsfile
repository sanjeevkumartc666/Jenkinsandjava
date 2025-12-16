pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sanjeevkumartc666/Jenkinsandjava.git'
        AWS_REGION = 'ap-south-1'
        ECR_REPO_NAME = 'jenkinsecr'
        ECR_PUBLIC_REPO_URI = 'public.ecr.aws/i0m8d5u6/jenkinsecr' 
        IMAGE_TAG = 'latest'
        AWS_ACCOUNT_ID = '311145409616'
        IMAGE_URI = "${ECR_PUBLIC_REPO_URI}:${IMAGE_TAG}"
    }

    stages {
        stage('Install AWS CLI and Tools') {
            steps {
                script {
                    sh '''
                        set -e
                        echo "Installing prerequisite tools (Maven, Docker)..."
                        # Ensure these tools are installed on your Jenkins agent machine via 'sudo apt install -y'
                        sudo apt update && sudo apt install -y unzip curl maven docker.io || true 

                        # Assuming AWS CLI is installed system-wide from manual steps
                        aws --version
                        mvn --version
                    '''
                }
            }
        }

        stage('Clone Repository') {
            steps {
                git url: "${GIT_REPO}", branch: 'main'
            }
        }

        stage('Build Java Application') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Login to AWS ECR, Build & Push Docker Image') {
            steps {
                // This block injects the securely stored credentials into the environment variables
                // NOTE: Replace 'aws-credentials-id' with your actual Jenkins Credentials ID
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
    } // <-- This closes the 'stages' block

    post {
        success {
            echo "Docker image pushed to ECR successfully and deployed."
        }
        failure {
            echo "Pipeline failed."
        }
    }
} // <-- CRITICAL: This closes the main 'pipeline' block.
