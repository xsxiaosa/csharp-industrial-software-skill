# Device Communication Checklist

Use this checklist for camera, PLC, scanner, robot, OPC UA, Modbus TCP, and Omron FINS integrations.

## Required behavior

- Configurable IP, port, timeout, retry count, and station/device identity.
- Connection states: `Disconnected`, `Connecting`, `Connected`, `Reconnecting`, `Faulted`.
- Heartbeat when the protocol supports it.
- Idempotent trigger handling.
- Ack/Done/Error state clearly represented.
- Raw SDK or protocol errors mapped to business-level error codes.
- Fake/simulator implementation for development without hardware.
- Integration tests disabled by default unless environment variables enable them.

## Logging context

Every important log should include the relevant subset of:

- station id
- device name or serial number
- task key or sequence number
- protocol address or command name
- elapsed time
- raw error code
- mapped business error code

## Safety rules

- Do not assume all devices use the same endian, register layout, or string encoding.
- Do not ignore SDK error codes.
- Do not place protocol parsing directly in a ViewModel.
- Do not make camera callbacks update UI state directly.