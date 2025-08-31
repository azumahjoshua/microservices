pipeline {
    agent any
     environment {
        AWS_REGION = 'us-east-1'                  
        IMAGE_TAG = "${BUILD_NUMBER}"             
        ECR_REGISTRY_ALIAS = 'g8x5p5b7'

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
        stage('Authenticate to ECR Public') {
            steps {
                script {
                    sh """
                        aws ecr-public get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin public.ecr.aws
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
                        docker tag ${ECR_REPOSITORY_RAILS}:${IMAGE_TAG} public.ecr.aws/${ECR_REGISTRY_ALIAS}/${ECR_REPOSITORY_RAILS}:${IMAGE_TAG}
                        docker tag ${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG} public.ecr.aws/${ECR_REGISTRY_ALIAS}/${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG}
                        docker tag ${ECR_REPOSITORY_GO}:${IMAGE_TAG} public.ecr.aws/${ECR_REGISTRY_ALIAS}/${ECR_REPOSITORY_GO}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Push Docker Images') {
            steps {
                script {
                    sh """
                        docker push public.ecr.aws/${ECR_REGISTRY_ALIAS}/${ECR_REPOSITORY_RAILS}:${IMAGE_TAG}
                        docker push public.ecr.aws/${ECR_REGISTRY_ALIAS}/${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG}
                        docker push public.ecr.aws/${ECR_REGISTRY_ALIAS}/${ECR_REPOSITORY_GO}:${IMAGE_TAG}
                    """
                }
            }
        }
    
        stage('Verify Kubernetes Connection') {
            steps {
                script {
                    def result = sh(
                        script: "kubectl get nodes --kubeconfig ~/.kube/config -o wide",
                        returnStatus: true
                    )
                    if (result != 0) {
                        echo "Jenkins cannot access the EKS cluster yet."
                        currentBuild.result = 'UNSTABLE'
                    } else {
                        echo "Jenkins can access the EKS cluster."
                    }
                }
            }
        }
         stage('Deploy to Kubernetes') {
            when {
                expression {
                    // Only run if Jenkins already has cluster access
                    sh(script: "kubectl get ns kube-system --kubeconfig ~/.kube/config > /dev/null 2>&1", returnStatus: true) == 0
                }
            }
            steps {
                script {
                    echo "Deploying manifests to EKS..."
                    sh """
                        kubectl apply -f k8s/ --kubeconfig ~/.kube/config
                    """
                }
            }
        }

        // stage('Authenticate to ECR Public') {
        //     steps {
        //         script {
        //             sh """
        //                 aws ecr-public get-login-password --region ${AWS_REGION} | \
        //                 docker login --username AWS --password-stdin public.ecr.aws
        //             """
        //         }
        //     }
        // }

        // stage('Build Docker Images') {
        //     steps {
        //         script {
        //             sh """
        //                 docker build -t ${ECR_REPOSITORY_RAILS}:${IMAGE_TAG} ./rails-app
        //                 docker build -t ${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG} ./python-service
        //                 docker build -t ${ECR_REPOSITORY_GO}:${IMAGE_TAG} ./go-service
        //             """
        //         }
        //     }
        // }

        // stage('Tag Docker Images') {
        //     steps {
        //         script {
        //             sh """
        //                 docker tag ${ECR_REPOSITORY_RAILS}:${IMAGE_TAG} public.ecr.aws/${ECR_REPOSITORY_RAILS}:${IMAGE_TAG}
        //                 docker tag ${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG} public.ecr.aws/${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG}
        //                 docker tag ${ECR_REPOSITORY_GO}:${IMAGE_TAG} public.ecr.aws/${ECR_REPOSITORY_GO}:${IMAGE_TAG}
        //             """
        //         }
        //     }
        // }

        // stage('Push Docker Images') {
        //     steps {
        //         script {
        //             sh """
        //                 docker push public.ecr.aws/${ECR_REPOSITORY_RAILS}:${IMAGE_TAG}
        //                 docker push public.ecr.aws/${ECR_REPOSITORY_PYTHON}:${IMAGE_TAG}
        //                 docker push public.ecr.aws/${ECR_REPOSITORY_GO}:${IMAGE_TAG}
        //             """
        //         }
        //     }
        // }
    }

    post {
        always {
            cleanWs()
        }
    }
}