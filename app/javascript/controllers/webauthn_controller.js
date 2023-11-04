import { Controller } from "@hotwired/stimulus";
import { create, get } from "@github/webauthn-json";

export default class extends Controller {
  static values = { options: String, verify: String };

  connect() {}

  async register() {
    console.log(JSON.parse(this.optionsValue));

    const credential = await create({
      publicKey: JSON.parse(this.optionsValue),
    });

    console.log({ credential });

    await fetch("/account/register_callback", {
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
