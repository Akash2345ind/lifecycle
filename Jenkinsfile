pipeline {
    agent any

    environment {
        DOCKER_USERNAME = 'viswanadh7'  // Replace with your DockerHub username
        IMAGE_NAME = 'devops-demo'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/ViswaVK123/Devops-lifecycle-Demo'
            }
        }

        stage('2. Build Docker Image') {
            steps {
                script {
                    def imageTag = "${DOCKER_USERNAME}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker build -t ${imageTag} ."
                }
            }
        }

        stage('3. Push to Docker Hub') {
            steps {
                script {
                    def imageTag = "${DOCKER_USERNAME}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    def latestTag = "${DOCKER_USERNAME}/${IMAGE_NAME}:latest"

                    withCredentials([usernamePassword(credentialsId: 'Dockerhub_creds', usernameVariable: 'docker_user', passwordVariable: 'docker_pass')]) {
                        sh """
                            echo \${docker_pass} | docker login -u \${docker_user} --password-stdin
                            docker tag ${imageTag} ${latestTag}
                            docker push ${imageTag}
                            docker push ${latestTag}
                        """
                    }
                }
            }
        }

        stage('4. Deploy to Kubernetes') {
            steps {
                script {
                    def imageTag = "${DOCKER_USERNAME}/${IMAGE_NAME}:${BUILD_NUMBER}"

                    sh """
                        export KUBECONFIG=/var/lib/jenkins/.kube/config
                        sed 's|image: .*|image: ${imageTag}|' deployment.yaml > updated-deployment.yaml
                        kubectl apply -f updated-deployment.yaml
                        kubectl apply -f service.yaml
                    """
                }
            }
        }

        stage('5. Cleanup Docker Images') {
            steps {
                sh "docker image prune -af"
            }
        }
    }
}
