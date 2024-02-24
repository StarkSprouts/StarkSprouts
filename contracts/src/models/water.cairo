// #[derive(Serde, Copy, Drop, Introspect)]
// enum WaterState {
//     Quenched,
//     Thirsty,
//     Dry,
//     Dead,
// }

// corresponds to water level, 0-100
#[derive(Serde, Copy, Drop, Introspect)]
enum WaterState {
    Quenched, // 80-100
    LittleThirsty, // 
    Thirsty,
    Dry,
    Dead,
}
