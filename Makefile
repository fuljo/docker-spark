images = spark-base spark-driver

# Build arguments
ALPINE_VERSION = 3.13
SPARK_VERSION = 3.1.1
SPARK_MAJOR_VERSION != echo $(SPARK_VERSION) | cut -d '.' -f 1
HADOOP_VERSION = 3.2
JAVA_VERSION = 11

# Tag for all images
FULL_IMAGE_TAG = $(SPARK_VERSION)-hadoop$(HADOOP_VERSION)-java$(JAVA_VERSION)
MAJOR_JAVA_IMAGE_TAG = ${SPARK_MAJOR_VERSION}-java$(JAVA_VERSION)
MAJOR_IMAGE_TAG = $(SPARK_MAJOR_VERSION)
# Compile all images
all: $(images)

.PHONY: all $(images) example

# Build a specific image (locally)
$(images):
	docker build \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg SPARK_VERSION=$(SPARK_VERSION) \
		--build-arg HADOOP_VERSION=$(HADOOP_VERSION) \
		--build-arg JAVA_VERSION=$(JAVA_VERSION) \
		-t fuljo/$@:$(FULL_IMAGE_TAG) \
		-t fuljo/$@:$(MAJOR_JAVA_IMAGE_TAG) \
		-t fuljo/$@:$(MAJOR_IMAGE_TAG) \
		-t fuljo/$@:latest \
		$@/

# Build the example
example: $(images)
	docker build \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		--build-arg SPARK_VERSION=$(SPARK_VERSION) \
		--build-arg HADOOP_VERSION=$(HADOOP_VERSION) \
		--build-arg JAVA_VERSION=$(JAVA_VERSION) \
		-t fuljo/word-count-spark:latest \
		$@/

# Publish the images to Docker Hub
publish: $(images)
	docker push fuljo/spark-base:$(FULL_IMAGE_TAG)
	docker push fuljo/spark-base:$(MAJOR_JAVA_IMAGE_TAG)
	docker push fuljo/spark-base:$(MAJOR_IMAGE_TAG)
	docker push fuljo/spark-base:latest
	docker push fuljo/spark-driver:$(FULL_IMAGE_TAG)
	docker push fuljo/spark-driver:$(MAJOR_JAVA_IMAGE_TAG)
	docker push fuljo/spark-driver:$(MAJOR_IMAGE_TAG)
	docker push fuljo/spark-driver:latest