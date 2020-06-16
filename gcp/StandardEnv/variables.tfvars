projectID = "pwolthausen"

region1 = "northamerica-northeast1"

zone1 = "northamerica-northeast1-a"

automation_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCypoaJw+vsHE5OU+uZ0MxwkpGxzaGy5+nmH23/6dnywRXKmlzJ9XjTxpJgTQM+VdXYK6P716ICRaXCo+5R0W4SWwsQcrepgca01zyO6oJ9/DGewmzVZcohPcFFijUpxtOb+WZ3UGKAqm0GeAK5GshwsLOzNfduGmO1ec8uO587CniCjvRL0vV0telPUIVUu5595rhXcRYumefqe6keARncUfy07Djs+QqrQ6/s7NW7WeP8HT+TLGCfMKK54NJ8D/2rQJWCTXNbT1ELvUoMXi/9H8w/LOvXPV4DdcfI4RnSan9wqVslP2t3HnEw6YZqRtqAj7tKX6DtVKux5lBoaIGnHpQwJBeYzVZ2OG2I5YJi2GsY8kBR7iOyDV20QP4qrrcTJWGHrOkVZmPxptOz6bB54wi2h9pnR7RQTkA0z04Sd0eGMH8ZHio/0JBFXIm+VscqnjtezL+c/0POHGrKp1lYa2Vx+xQdhtlfbt/fKuigSPwBfZPZuqb2s3j8JMxelz0= automation@ansible.form"

client_admin_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDqNoaX2Lpqa2U6gR/+CIlu5lf2+zRO1GIYiMFKJLFV2y2BntRfmVkkHKF7NuMUGO4Nr0tUTirB1pLKewF4seU44Ems7hpJT/I+0U9TBz3rXL2NjxJza2bmBSswTzz0t/L+TS/D8IaNvfMPSxTljXol0FvRku9aPZ7+MdU83cs8CDvSPKxRQjfbQt/j4NoJPVSDTprTaulFOlbdAnhQ+83k14sAt3fovIyx/W9YMRYZR87Hm1rYClc940DXHTzIfI5hLWqZ3Dnj2OG6VXUwJ5ovyRzeWBPnC5KJmbkZbJ5yrotgpzm8ssI1pimMIWczaG21ETc3fBryZIo7Cnw+IeDniARNpP5ePuKnq7yV361rDJw4z3M8vIJhhBrSTOUMxfoLtgYAD74LzwBqfT5rmt2slSITiOrhzceVuGVzPoiWW2LZEDsM1iZkV8QhbEMsrQUISk22vmaQiS+0kO9BzMAyWc0hDRg69lB48J3ouG96x1BsR9ULTwWMYGZxiXkxsu0= admin@local.com"

##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#
##This full block must be repeated for every different instance type
servers1              = "frontend"
servers1_machine_type = "custom-4-8192"
server1_bootdisk_size = "20"
server1_datadisk_size = "200"
server1_replicas      = "3"

servers1_image_family  = "debian-10"
servers1_image_project = "debian-cloud"

##+#+#+#+#+#+#+#+#+#+##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#

db_version = "POSTGRES_11"
db_tier    = "db-custom-2-13312"
