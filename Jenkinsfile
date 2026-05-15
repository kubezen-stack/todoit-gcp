pipeline {
    agent none

    environment {
        POSTGRES_USER = credentials('postgres_user')
        POSTGRES_PASSWORD = credentials('postgres_password')
        POSTGRES_DB = credentials('postgres_db')
        GCP_PROJECT_ID = credentials('gcp_project_id')
        GOOGLE_CREDENTIALS = credentials('gcp-service-account')
        IMAGE_NAME = 'todo-api'
    }

    stages {
        stage ('Checkout') {
            agent { label 'git' }
            steps {
                git branch: 'main', url: 'https://github.com/kubezen-stack/todoit-gcp.git'
            }
        }

        stage('Test') {
            agent { label 'python' }
            steps {
                sh 'pip install -r app/requirements.txt'
                sh 'pytest app/tests/ -v'
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
                    gcloud secrets versions access latest \
                        --secret=ansible-ssh-private-key \
                        --project=${GCP_PROJECT_ID} > ~/.ssh/ansible_key

                    chmod 600 ~/.ssh/ansible_key

                    export ANSIBLE_SA_UNIQUE_ID=$(gcloud iam service-accounts describe \
                        jenkins-project-dev-sa@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
                        --format='value(uniqueId)')

                    ansible-playbook \
                        -i inventory/gcp_compute.yml \
                        playbook.yml \
                        --private-key=~/.ssh/ansible_key

                    rm ~/.ssh/ansible_key
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