pipeline {
    agent none

    environment {
        POSTGRES_USER = credentials('postgres_user')
        POSTGRES_PASSWORD = credentials('postgres_password')
        POSTGRES_DB = credentials('postgres_db')
        GOOGLE_CREDENTIALS = credentials('gcp-service-account')
        IMAGE_NAME = 'todo-api'
    }

    stages {
        stage ('Checkout') {
            agent { label 'git' }
            steps {
                git branch: 'main', url: 'https://github.com/brunopinto/todo-app.git'
            }
        }

        stage('Test') {
            agent { label 'python' }
            steps {
                sh 'pip install -r requirements.txt'
                sh 'pytest tests/ -v'
            }
        }

        stage('Build Docker Image') {
            agent { label 'docker' }
            steps {
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ./app'
                sh 'docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest'
            }
        }

        stage('Terraform') {
            agent {
                docker {
                    image 'hashicorp/terraform:latest'
                    args '-v ${WORKSPACE}/terraform:/workspace -w /workspace'
                }
            }
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible') {
            agent { label 'ansible' }
            steps {
                dir('ansible') {
                    sh '''
                    ansible-playbook \
                        -i inventory/gcp_compute.yml \
                        playbook.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for details.'
        }
    }
}