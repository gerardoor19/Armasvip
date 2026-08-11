# Security

ArmasVIP uses a server-authoritative model for privileged and ownership-sensitive operations.

The NUI and client are not authorization boundaries. Administrative actions must pass ACE validation on the server, and player operations are validated against persistent grant ownership and current inventory state.

## Trust boundaries

The server revalidates sensitive requests using server-side state where applicable, including:

- administrative ACE permission;
- persistent player identity;
- grant existence and active status;
- grant owner;
- weapon associated with the grant;
- VIP metadata and `vipGrantId`;
- current inventory instance state;
- cosmetic entitlement;
- duplicate recovery attempts.

Transfer protection is registered through the supported `ox_inventory` hook system rather than by modifying the inventory resource.

## Public deployment guidance

- Do not place database credentials, webhooks, API tokens or private identifiers in this resource.
- Keep database credentials in your private server configuration/environment, not in Git.
- Never commit production database dumps or player identifier lists.
- Review changes before deployment and test on a development server.
- Keep dependencies sourced from their official projects and update deliberately.

If you discover a security issue, avoid publishing actionable exploitation details in a public issue before maintainers have had an opportunity to review it.
