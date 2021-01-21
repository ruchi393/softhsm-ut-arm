# softhsm-ut-arm

## Getting the code

Follow all steps and create build environment for QEMU_v8. (qemu_v8.xml)
See - https://optee.readthedocs.io/en/latest/building/gits/build.html#get-and-build-the-solution.

Once the build environment is ready.

```
  $ cd <optee-project>
  $ git clone  https://github.com/ruchi393/softhsm-ut-arm.git
```

## Compiling the Library

```
  $ cd softhsm-ut-arm
  $ make
```

## Getting the alias (required for run environment)

```
  $ cd softhsm-ut-arm
  $ make qemu_help
```

### Run

```bash
$ cd <optee-project>/build
$ make -j`nproc` QEMU_VIRTFS_ENABLE=y run
```

#### Shell 1 - QEMU:
```
(qemu) c
```

#### Shell 2 - QEMU:NW
Get the alias for your environment as mentioned in steps above.
Here we will login, run alias `setup_softhsmtest`.

```
buildroot login: root
# alias setup_softhsmtest='mkdir -p /host && mount -t 9p -o trans=virtio host /host && ln -sf /host/softhsm-ut-arm/out/openssl/lib/libcrypto.so.3 /usr/lib/ && ln -sf /host/softhsm-ut-arm/out/cppunit/install/lib/libcppunit-1.15.so.1 /usr/lib/ && ln -sf /host/softhsm-ut-arm/out/softhsm/src/lib/test/p11test /usr/bin/'
# setup_softhsmtest
# p11test
```
Many tests fail right now and tests hang after 55). This needs to be investigated.
For development phase, you can try running individual test cases.

To run a specific test :

```bash
# p11test ObjectTests::testDestroyObject
```

[You can check specific tests from softhsm-ut-arm/softhsm/src/lib/test/ in respective *.cpp files]
