//:______________________________________________________________________
//  ᛝ confy  |  Copyright (C) Ivan Mar (sOkam!)  |  GNU GPLv3 or later  :
//:______________________________________________________________________
// @deps git
import { Octokit } from "@octokit/core"
import { restEndpointMethods } from "@octokit/plugin-rest-endpoint-methods";

const GitHub = Octokit.plugin(restEndpointMethods);
export const gh = new GitHub({})

