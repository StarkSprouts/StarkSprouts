use starknet::ContractAddress;

#[starknet::interface]
trait ISeed<TContractState> {
    /// Reads
    fn get_dojo_address(self: @TContractState) -> ContractAddress;
    /// Writes
    fn initializer(ref self: TContractState);
    fn set_dojo_address(ref self: TContractState, dojo_address: ContractAddress);
    fn mint_seeds(ref self: TContractState, player: ContractAddress, amount: u256);
    fn burn_seeds(ref self: TContractState, player: ContractAddress, amount: u256);
}
