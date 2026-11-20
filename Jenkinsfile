pipeline {
    agent any

    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building TaskFlow application...'
                sh '''
                    python3 -m venv .venv
                    .venv/bin/pip install --upgrade pip
                    .venv/bin/pip install -r requirements.txt
                '''
            }
        }

        stage('Test') {
            steps {
                echo 'Running TaskFlow tests...'
                sh '''
                    .venv/bin/pytest -v --junitxml=test-results.xml
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'test-results.xml'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Applying Kubernetes manifests...'
                sh '''
                    /usr/local/bin/kubectl apply -f k8s/deployment.yaml
                    /usr/local/bin/kubectl apply -f k8s/service.yaml

                    /usr/local/bin/kubectl rollout status deployment/taskflow --timeout=120s

                    /usr/local/bin/kubectl get pods
                    /usr/local/bin/kubectl get services
                '''
            }
        }
    }

    post {
        success {
            echo 'TaskFlow Kubernetes CI/CD pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}

