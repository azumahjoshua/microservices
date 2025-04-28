pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'                  
        IMAGE_TAG = "${BUILD_NUMBER}"             

        ECR_REPOSITORY_RAILS = 'rails-service-repo'    
        ECR_REPOSITORY_PYTHON = 'python-service-repo'   
        ECR_REPOSITORY_GO = 'go-service-repo'          
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Check Folders Exist') {
            steps {
                script {
                    sh """
                        if [ ! -d "./rails-app" ]; then
                          echo "Error: rails-app directory does not exist!"
                          exit 1
                        fi

                        if [ ! -d "./python-service" ]; then
                          echo "Error: python-service directory does not exist!"
                          exit 1
                        fi

                        if [ ! -d "./go-service" ]; then
                          echo "Error: go-service directory does not exist!"
                          exit 1
                        fi
                    """
                }
            }
        }

        stage('Retrieve AWS Account ID') {
            steps {
                script {
                    env.AWS_ACCOUNT_ID = sh(
                        script: "aws sts get-caller-identity --query Account --output text",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Authenticate to ECR') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    sh """
                        docker build -t ${ECR_REPOSITORY_RAILS}:${IMAGE_TAG} ./rails-app
                        docker build -t ${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG} ./python-service
                        docker build -t ${ECR_REPOSITORY_GO}:${IMAGE_TAG} ./go-service
                    """
                }
            }
        }

        stage('Tag Docker Images') {
            steps {
                script {
                    sh """
                        docker tag ${ECR_REPOSITORY_RAILS}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_RAILS}:${IMAGE_TAG}
                        docker tag ${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG}
                        docker tag ${ECR_REPOSITORY_GO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_GO}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    sh """
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_RAILS}:${IMAGE_TAG}
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG}
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_GO}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
