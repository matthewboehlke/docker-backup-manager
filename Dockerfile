FROM alpine:3.16

# Non-root user for security purposes.
#
# UIDs below 10,000 are a security risk, as a container breakout could result
# in the container being ran as a more privileged user on the host kernel with
# the same UID.
#
# Static GID/UID is also useful for chown'ing files outside the container where
# such a user does not exist.
RUN addgroup --gid 10001 --system nonroot \
    && adduser  --uid 10000 --system --ingroup nonroot --home /home/nonroot nonroot

# environment settings
ENV PYTHONUNBUFFERED=1

# add local files
COPY root/ /

RUN \
    echo "**** install packages ****" && \
    apk add --no-cache python3 bash mariadb-client ca-certificates postgresql-client tini && \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \ 
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    pip3 install --no-cache --upgrade boto3 s3cmd


ENTRYPOINT ["/sbin/tini", "--", "python3", "/app/backup.py"]

USER nonroot

CMD ["2>&1", ">", "/config/backup.log"]

