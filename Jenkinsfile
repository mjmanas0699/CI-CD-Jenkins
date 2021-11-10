//---------JOB1---
job('Repo-Clonning') {
    scm {
        github('mjmanas0699/dotsquare', 'main')
    }
    steps {
        triggers {
            upstream('seed job', 'SUCCESS')
        }
    }
}
//-----------JOB2---

job('Create Repository') {
    steps {
        shell(''' #/bin/bash
                aws ecr describe-repositories --repository-name=test-cli
                a=$?
                if [ $a -eq 0 ]; then
                     echo "Repo present"
                else
                     aws ecr create-repository --repository-name test-cli
                     echo "Repo Creation Done"
                fi
                 ''')

        triggers {
            upstream('Repo-Clonning', 'SUCCESS')
        }
    }
}

// #-------------
job('Build the Image') {
    steps {
        shell(''' #/bin/bash
                repo_name=$(aws ecr describe-repositories --repository-names=test-cli --query='repositories[].repositoryUri' --output text)
                last_commit=$(git rev-parse HEAD)
                sudo docker build -t $repo_name:$last_commit .

                 ''')
        triggers {
            upstream('Create Repository', 'SUCCESS')
        }
    }
}
