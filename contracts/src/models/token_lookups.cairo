use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct TokenLookups {
    #[key]
    seed_id: u16,
    erc20_address: ContractAddress,
}

trait TokenLookupsTrait {
    fn set_erc20_address(ref self: TokenLookups, erc20_address: ContractAddress);
}

impl TokenLookupsImpl of TokenLookupsTrait {
    fn set_erc20_address(ref self: TokenLookups, erc20_address: ContractAddress) {
        self.erc20_address = erc20_address;
    }
}

#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{TokenLookups, TokenLookupsTrait, TokenLookupsImpl};

    #[test]
    #[available_gas(1000000)]
    fn test_set_erc20_address() {
        let mut token_lookups = TokenLookups {
            seed_id: 1_u16, erc20_address: starknet::contract_address_const::<'token'>(),
        };
        token_lookups.set_erc20_address(starknet::contract_address_const::<'new_token'>());
        assert(
            token_lookups.erc20_address == starknet::contract_address_const::<'new_token'>(),
            'wrong erc20_address'
        );
    }
}
