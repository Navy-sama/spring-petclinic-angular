pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'DockerHub'
        DOCKER_IMAGE = "navysama/petclinic-frontend"
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        API_URL = "http://backend:9966/petclinic/api/"
    }

    tools {
        allure 'Allure 2.36.0'
        dockerTool 'Docker --latest'
    }

    stages {
        
        stage('Docker Build & Push') {
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                        def frontendImage = docker.build(
                            "${DOCKER_IMAGE}:${DOCKER_TAG}",
                            "--build-arg API_URL=${API_URL} ."
                        )
                        
                        docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                            frontendImage.push("latest")
                        }
                    }
                }
            }
            post {
                success {
                    script {
                        def current = env.BUILD_NUMBER.toInteger()
                        
                        if (current > 1) {
                            def previousTag = (current - 1).toString()
                            
                            echo "Suppression de l'ancienne image : ${DOCKER_IMAGE}:${previousTag}"
                            sh "docker rmi ${DOCKER_IMAGE}:${previousTag} || true"
                        }
                    }
                }
            }
        }

        stage('Gen Allure report') {
            steps {
                allure includeProperties: false, jdk: '', resultPolicy: 'LEAVE_AS_IS', results: [[path: 'target/allure-results']]
            }
        }
    }

    post {
        always {
            echo "Fin d'éxécution"
        }
        success {
            echo "✅ Ca a chou - Image frontend générée et poussée avec succès"
        }
        aborted {
            echo "🚫 Tué, tué, tué"
        }
        failure {
            echo "❌ Gaing gaing gaing - Échec du build ou du push"
        }
    }
}
