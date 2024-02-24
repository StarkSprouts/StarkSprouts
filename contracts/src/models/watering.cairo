#[derive(Serde, Copy, Drop, Introspect)]
enum WaterState {
    Quenched,
    Thirsty,
    Dry,
    Dead,
}
