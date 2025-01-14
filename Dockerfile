FROM golang:alpine as builder

RUN apk update && apk upgrade && apk add --no-cache curl git

RUN curl -s https://raw.githubusercontent.com/eficode/wait-for/master/wait-for -o /usr/bin/wait-for
RUN chmod +x /usr/bin/wait-for

RUN mkdir /tmp/pubsub-emulator

COPY main.go /tmp/pubsub-emulator/main.go

WORKDIR /tmp/pubsub-emulator

RUN go mod init gcloud-pubsub-emulator
RUN go get gcloud-pubsub-emulator
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o gcloud-pubsub-emulator

###############################################################################

FROM google/cloud-sdk:alpine

RUN apk --update add openjdk8-jre netcat-openbsd && gcloud components install beta pubsub-emulator

COPY --from=builder /usr/bin/wait-for /usr/bin/
COPY --from=builder /tmp/pubsub-emulator/gcloud-pubsub-emulator /usr/bin/gcloud-pubsub-emulator

COPY                run.sh            /run.sh

EXPOSE 8681

CMD /run.sh
