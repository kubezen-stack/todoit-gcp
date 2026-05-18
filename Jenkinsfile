pipeline {
    agent none

    environment {
        REGISTRY        = 'us-central1-docker.pkg.dev'
        PROJECT_ID      = 'todo-app-496222'
        REPOSITORY      = 'todo-app'
        IMAGE_NAME      = 'todo-api'
        FULL_IMAGE_PATH = "${REGISTRY}/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}"
        
        POSTGRES_USER     = credentials('postgres_user')
        POSTGRES_PASSWORD = credentials('postgres_password')
        POSTGRES_DB       = credentials('postgres_db')
    }

    stages {
        stage('Checkout') {
            agent { label 'git' }
            steps {
                cleanWs()
                git branch: 'main', url: 'https://github.com/kubezen-stack/todoit-gcp.git'
            }
        }

        stage('Test') {
            agent { label 'python' }
            steps {
                sh '''
                    pip3 install --user --no-cache-dir -r app/requirements.txt
                    export DATABASE_URL="sqlite:///:memory:"
                    PYTHONPATH=app python3 -m pytest app/tests/ -v
                '''
            }
            post {
                always { cleanWs() }
            }
        }

        stage('Build & Push Docker Image') {
            agent { label 'docker' }
            steps {
                sh '''
                    gcloud auth configure-docker ${REGISTRY} --quiet
                    docker build --platform linux/amd64 -t ${FULL_IMAGE_PATH}:${BUILD_NUMBER} ./app
                    docker tag ${FULL_IMAGE_PATH}:${BUILD_NUMBER} ${FULL_IMAGE_PATH}:latest
                    docker push ${FULL_IMAGE_PATH}:${BUILD_NUMBER}
                    docker push ${FULL_IMAGE_PATH}:latest
                '''
            }
            post {
                always { cleanWs() }
            }
        }

        stage('Terraform') {
            agent { label 'terraform' }
            steps {
                dir('terraform') {
                    sh '''
                        terraform init -input=false
                        terraform plan -out=tfplan -input=false
                        terraform apply -input=false tfplan
                    '''
                }
            }
        }

        stage('Ansible Deployment') {
            agent { label 'ansible' }
            steps {
                dir('ansible') {
                    withEnv([
                        "ANSIBLE_HOST_KEY_CHECKING=False",
                        "POSTGRES_USER=${POSTGRES_USER}",
                        "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}",
                        "POSTGRES_DB=${POSTGRES_DB}"
                    ]) {
                        sh '''
                        ansible-playbook \
                            -i inventory/gcp_compute.yml \
                            playbook.yml \
                            --extra-vars "postgres_user=${POSTGRES_USER} postgres_password=${POSTGRES_PASSWORD} postgres_db=${POSTGRES_DB}"
                        '''
                    }
                }
            }
            post {
                always { cleanWs() }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! Built and deployed: ${FULL_IMAGE_PATH}:${BUILD_NUMBER}"
        }
        failure {
            echo "Pipeline failed during processing. Please review console outputs above."
        }
    }
}