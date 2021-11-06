FROM debian:bullseye-slim
# FROM alpine:3.6

WORKDIR /app

RUN apt-get update && apt-get install -y nano procps bash cron

COPY . ./

ENTRYPOINT ["bash", "entrypoint_with_cronjobs.sh"]

# CMD ["crond", "-f", "-d", "8"] # For alpine, but alpine's cron doesn't have the @reboot macro
CMD ["/usr/sbin/cron", "-f", "-L", "/dev/stdout"] # For debian
