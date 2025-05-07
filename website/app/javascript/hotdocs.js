import "@hotwired/turbo-rails";
import "controllers";

import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("hotdocs/controllers", application)
