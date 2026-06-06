fn main() {

    // Prevent cargo from scanning all files in src-tauri, which can fail
    // on nested directories or permission-restricted paths.
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=../tauri.conf.json");
    println!("cargo:rerun-if-changed=Cargo.toml");
    
    tauri_build::build()
}
