install:
	helm install -f $(filter-out $@,$(MAKECMDGOALS))/values.yaml $(filter-out $@,$(MAKECMDGOALS)) ./common 

upgrade:
	helm upgrade -f $(filter-out $@,$(MAKECMDGOALS))/values.yaml $(filter-out $@,$(MAKECMDGOALS)) ./common 

%:
	@:
