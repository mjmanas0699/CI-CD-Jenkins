//---------JOB1---
job('Repo-Clonning') {
    scm {
        github('mjmanas0699/dotsquare','main')
    }
    steps{
        shell('''
                  mkdir ~/tasks
                  sudo cp -rvf * ~/tasks
              ''')
    triggers {
        upstream('JOB DSL', 'SUCCESS')
            }
 }

}
//-----------JOB2---
// job('Build the Image') {

//     steps{
//         shell('''

//                  ''')
//     triggers {
//         upstream('Repo-Clonning', 'SUCCESS')
//     }
//     }

//     }