
pipeline {
    agent any

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

        stage('Deploy') {
            steps {
                echo 'Deploying TaskFlow application...'
                sh '''
                    if [ -f taskflow.pid ]; then
                        kill "$(cat taskflow.pid)" 2>/dev/null || true
                        rm -f taskflow.pid
                    fi

                    nohup .venv/bin/python app.py > taskflow.log 2>&1 &
                    echo $! > taskflow.pid

                    for i in $(seq 1 15); do
                        if curl -fsS http://127.0.0.1:5000/health; then
                            echo "TaskFlow deployment successful!"
                            exit 0
                        fi
                        sleep 2
                    done

                    echo "Deployment health check failed."
                    cat taskflow.log
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo 'TaskFlow CI/CD pipeline completed successfully!'
        }
        failure {
            echo 'TaskFlow CI/CD pipeline failed. Check the console output.'
        }
        always {
            archiveArtifacts artifacts: 'taskflow.log',
                             allowEmptyArchive: true
        }
    }
}
