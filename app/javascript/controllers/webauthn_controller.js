import { Controller } from "@hotwired/stimulus";
import { create, get } from "@github/webauthn-json";

export default class extends Controller {
  static values = { verify: String };

  connect() {}

  async register() {
    const options = await (await fetch("/account/passkey_options")).json();

    const credential = await create({
      publicKey: options,
    });

    console.log({ credential });

    await fetch("/account/register_passkey", {
      body: JSON.stringify(credential),
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    });

    location.href = "/";
  }

  async verify() {
    const options = JSON.parse(this.verifyValue);
    const response = await get({ publicKey: options });

    const fetchResult = await fetch("/account/verify_callback", {
      body: JSON.stringify(response),
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (fetchResult.status === 200) {
      location.href = "/";
    }
  }
}
