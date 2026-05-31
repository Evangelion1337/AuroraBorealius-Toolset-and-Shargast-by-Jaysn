fn main() {
    let args: Vec<String> = std::env::args().collect();

    // No arguments or just "gui" → launch GUI
    if args.len() <= 1 || (args.len() == 2 && args[1] == "gui") {
        println!("The Aurora BorealiuS Toolset v{}", env!("CARGO_PKG_VERSION"));
        println!("Starting...");
        #[cfg(not(target_arch = "wasm32"))]
        aurora_borealis::run_native();
        return;
    }

    // Otherwise, run CLI command
    #[cfg(not(target_arch = "wasm32"))]
    aurora_borealis::run_cli(&args);
}
