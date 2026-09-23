# Local build notes (this file is not upstream)

Built 2026-09-19 on macOS (Apple clang 21, cmake 4.4.3 via Homebrew).

The bundled thirdparty/fmt 10.2.1 fails under Apple clang 21's consteval
enforcement ("call to consteval function ... is not a constant expression"
in format-inl.h). Workaround — configure with the format-string
compile-time checks disabled; no source edits needed:

    cd build
    cmake -DCMAKE_BUILD_TYPE=release -DCMAKE_CXX_FLAGS="-DFMT_CONSTEVAL=" ..
    make -j8

Binaries land in build/bin (Adams, ss). Smoke test used:

    ./Adams res S0 60      # 0.1 s, 360 Ext generators
    ./Adams prod S0 60
    ./Adams export S0 60   # -> S0_AdamsSS.db

S0_AdamsSS.db tables: S0_AdamsE2_generators (id,name,repr,s,t),
S0_AdamsE2_relations (rel,s,t), S0_AdamsE2_basis (id,mon,repr,s,t), version.
Sanity-checked: generators at (s,t)=(1,1),(1,2),(1,4),(1,8),(1,16) are
h0..h4; (3,11)=c0, (5,14)=Ph1.

The whole SSeqCpp/ directory is gitignored in the parent repo; local
modifications and .db outputs stay off the remote.
