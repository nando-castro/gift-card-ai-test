import { Request, Response, Router } from "express";

const suggestionRouter = Router();

suggestionRouter.get("/api/v1/suggestions", (req: Request, res: Response) => {
    res.send("Suggestions");
});

export { suggestionRouter };

