pipeline {
    agent none

    environment {
        POSTGRES_USER = credentials('postgres_user')
        POSTGRES_PASSWORD = credentials('postgres_password')
        POSTGRES_DB = credentials('postgres_db')
        GCP_PROJECT_ID = credentials('gcp_project_id')
        IMAGE_NAME = 'todo-api'
    }

    stages {
        stage('Checkout') {
            agent { label 'git' }
            steps {
                git branch: 'main', url: 'https://github.com/kubezen-stack/todoit-gcp.git'
            }
        }

        stage('Test') {
            agent { label 'python' }
            steps {
                sh 'pip3 install -r app/requirements.txt'
                sh 'python3 -m pytest app/tests/ -v'
            }
        }

        stage('Build Docker Image') {
            agent { label 'docker' }
            steps {
                sh '''
                    gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
                    docker build -t us-central1-docker.pkg.dev/todo-app-496222/todo-app/todo-api:${BUILD_NUMBER} ./app
                    docker tag us-central1-docker.pkg.dev/todo-app-496222/todo-app/todo-api:${BUILD_NUMBER} \
                            us-central1-docker.pkg.dev/todo-app-496222/todo-app/todo-api:latest
                    docker push us-central1-docker.pkg.dev/todo-app-496222/todo-app/todo-api:latest
                '''
            }
        }

        stage('Terraform') {
            agent { label 'ansible' }
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
                        playbook.yml \
                        --ssh-common-args="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
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