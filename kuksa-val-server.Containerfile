FROM alpine:3.11 as build

LABEL maintainer="Mohan Raj Janardhan <mjanardh@redhat.com>"

RUN apk update && apk add cmake wget alpine-sdk linux-headers openssl-dev libstdc++ mosquitto-dev

#Build Boost 1.75
#ENV BOOST_VER=1.75.0
#ENV BOOST_VER_=1_75_0
#RUN wget   https://boostorg.jfrog.io/artifactory/main/release/${BOOST_VER}/source/boost_${BOOST_VER_}.tar.bz2
#RUN tar xvjf boost_${BOOST_VER_}.tar.bz2
#WORKDIR /boost_${BOOST_VER_}
#RUN ./bootstrap.sh
#RUN ./b2 -j 6 install

WORKDIR /
# Build and install grpc
ENV GRPC_VER=1.44.0
RUN git clone --recurse-submodules -b v${GRPC_VER}  --single-branch --depth 1 --shallow-submodules https://github.com/grpc/grpc
RUN mkdir -p /grpc/build
WORKDIR /grpc/build
RUN cmake -DgRPC_INSTALL=ON  -DgRPC_BUILD_TESTS=OFF -DgRPC_SSL_PROVIDER=package ..
RUN make -j 6
RUN make install
RUN mkdir -p /grpc/third_party/abseil-cpp/build
WORKDIR /grpc/third_party/abseil-cpp/build
RUN cmake -DCMAKE_POSITION_INDEPENDENT_CODE=TRUE ..
RUN make -j 6
RUN make install

WORKDIR /
RUN mkdir kuksa.val 
WORKDIR /kuksa.val
ADD . /kuksa.val
RUN git submodule update --init --recursive
RUN rm -rf /kuksa.val/kuksa-val-server/build &&  mkdir -p /kuksa.val/kuksa-val-server/build
WORKDIR /kuksa.val/kuksa-val-server/build
RUN cmake ..
WORKDIR /kuksa.val/kuksa-val-server/build/_deps/boost-src/tools/build/src
RUN ls -al
RUN cp bootstrap.jam ./engine/.
RUN cp build-system.jam ./engine/.
WORKDIR /kuksa.val/kuksa-val-server/build/_deps/boost-src/tools/build/src/engine
RUN ls -al
#RUN ./b2 --prefix= 
WORKDIR /kuksa.val/kuksa-val-server/build
RUN make -j 4
RUN ls
RUN /kuksa.val/kuksa-val-server/docker/collect-deployment-artifacts.sh


FROM alpine:3.11

COPY --from=build /deploy /kuksa.val
WORKDIR /kuksa.val

ENV LOG_LEVEL=INFO
#Usually you want this to be 0.0.0.0 when using porter port expose via -p.
ENV BIND_ADDRESS=0.0.0.0

EXPOSE 8090/tcp

CMD /kuksa.val/startkuksaval.sh

ENTRYPOINT ["/bin/sh"]
