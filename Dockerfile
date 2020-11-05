FROM golang:alpine as builder

RUN apk update && apk upgrade && apk add --no-cache curl git

RUN curl -s https://raw.githubusercontent.com/eficode/wait-for/master/wait-for -o /usr/bin/wait-for
RUN chmod +x /usr/bin/wait-for

RUN go get github.com/tech-tim/gcloud-pubsub-emulator

###############################################################################

FROM google/cloud-sdk:alpine

COPY --from=builder /usr/bin/wait-for /usr/bin
COPY --from=builder /go/bin/gcloud-pubsub-emulator /usr/bin
COPY                run.sh            /run.sh

RUN apk --update add openjdk8-jre netcat-openbsd && gcloud components install beta pubsub-emulator

EXPOSE 8681

CMD /run.sh
