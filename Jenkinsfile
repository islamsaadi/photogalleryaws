pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
	    stage("Verify tooling") {
            steps {
                sh '''
                    docker info
                    docker version
                    docker compose version
                '''
            }
        }
        stage("Clear all running docker containers") {
            steps {
                script {
                    try {
                        sh 'docker system prune -a -y'
                        sh 'docker rm -f $(docker ps -a -q)'
                    } catch (Exception e) {
                        echo 'No running container to clear up...'
                    }
                }
            }
        }
        stage("Start Docker") {
            steps {
                sh 'make up'
                sh 'docker compose ps'
            }
        }
        stage("Run Composer Install") {
            steps {
                sh 'docker compose run --rm composer install'
            }
        }
        stage("Run laravel artisans") {
            environment {
                DB_HOST = credentials("laravel-db-host")
                DB_DATABASE = credentials("laravel-database")
                DB_USERNAME = credentials("laravel-db-user")
                DB_PASSWORD = credentials("laravel-db-password")
            }
            steps {
                sh 'cp ./src/.env.example ./src/.env'
                sh 'echo DB_HOST=${DB_HOST} >> ./src/.env'
                sh 'echo DB_USERNAME=${DB_USERNAME} >> ./src/.env'
                sh 'echo DB_DATABASE=${DB_DATABASE} >> ./src/.env'
                sh 'echo DB_PASSWORD=${DB_PASSWORD} >> ./src/.env'
                sh 'docker compose run --rm artisan key:generate'
                sh 'docker compose run --rm artisan migrate'
                sh 'docker compose run --rm artisan storage:link'
            }
        }              
        stage("Run Tests") {
            steps {
                sh 'docker compose run --rm artisan test'
            }
        }
    }
}

