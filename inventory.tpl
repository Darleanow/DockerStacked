[managers]
swarm-manager ansible_connection=lxd

[workers]
swarm-worker1 ansible_connection=lxd
swarm-worker2 ansible_connection=lxd

[all:vars]
ansible_python_interpreter=/usr/bin/python3

manager_ip=${manager_ip}
worker1_ip=${worker1_ip}
worker2_ip=${worker2_ip}
